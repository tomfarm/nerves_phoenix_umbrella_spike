defmodule UserInterface.MemberController do
  use UserInterface.Web, :controller

  alias UserInterface.Member

  import UserInterface.NetworkConnectionHelper

  plug :scrub_params, "member" when action in [:create, :update]

  def index(conn, _params) do
    members = Repo.all(from m in Member, preload: :chores)

    render(conn, "index.html", members: members)
  end

  def new(conn, _params) do
    changeset = Member.changeset(%Member{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"member" => member_params}) do
    changeset = Member.changeset(%Member{}, member_params)

    case Repo.insert(changeset) do
      {:ok, _member} ->
        conn
        |> put_flash(:info, "Member created successfully.")
        |> redirect(to: member_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    member = Repo.get!(Member, id)
    render(conn, "show.html", member: member)
  end

  def edit(conn, %{"id" => id}) do
    member = Repo.get!(Member, id)
    changeset = Member.changeset(member)
    render(conn, "edit.html", member: member, changeset: changeset)
  end

  def update(conn, %{"id" => id, "member" => member_params}) do
    member = Repo.get!(Member, id)
    changeset = Member.changeset(member, member_params)

    case Repo.update(changeset) do
      {:ok, member} ->
        conn
        |> put_flash(:info, "Member updated successfully.")
        |> redirect(to: member_path(conn, :show, member))
      {:error, changeset} ->
        render(conn, "edit.html", member: member, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    member = Repo.get!(Member, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(member)

    conn
    |> put_flash(:info, "Member deleted successfully.")
    |> redirect(to: member_path(conn, :index))
  end

  def welcome(conn, _params) do
    members = Repo.all(from m in Member, preload: :chores)
    visitor_ip = Task.async(fn -> user_ip_address(conn) end)
    visitor_mac = Task.async(fn -> user_mac_address(conn) end)

    render(conn, "welcome.html", members: members, visitor_ip: Task.await(visitor_ip), visitor_mac: Task.await(visitor_mac))
  end
end
